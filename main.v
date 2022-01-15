import net.http
import os
import x.json2

const version = '1.0.0'

const api_base = 'https://api.github.com'

fn ensure_command(cmd string) {
	if os.system(cmd) != 0 {
		eprintln('fatal: command `$cmd` failed.')
		exit(1)
	}
}

[inline]
fn ensure_remote(owner string, repo string) {
	os.system('git remote add $owner https://github.com/$owner/${repo}.git')
}

// returns the name of the owner and the repository of the origin remote.
fn get_remote_info() (string, string) {
	url := os.execute('git remote get-url origin').output.trim_space()

	if url.contains('@') {
		// SSH url.
		parts := url.split(':')[1].split('/')
		return parts[0], parts[1].trim_string_right('.git')
	}

	parts := url.split('/')
	return parts[3], parts[4].trim_string_right('.git')
}

fn main() {
	if os.args.len != 2 {
		eprintln('checkout v$version
				 |
				 |USAGE: ${os.args[0]} <target>
				 |
				 |target - a required parameter which can either be a branch on the local repository,
				 |a GitHub PR number or a repository slug in {fork_owner}:{branch} format.
				 |
				 |This program will automatically add remotes required and set relevant upstreams for
				 |new branches checked-out from this program. Existing branches will not be affected.'.strip_margin())
		exit(2)
	}

	target := os.args[1].replace(':', '/')
	owner, repo := get_remote_info()
	branch_exists := os.system('git show-ref --verify --quiet refs/heads/$target') == 0

	if branch_exists {
		exit(os.system('git checkout $target'))
	} else if target.u64() != 0 {
		// GitHub PR numbering starts at 1 and string.u64() returns 0 on parsing failure
		// which makes this the perfect condition to use.s
		data := json2.raw_decode(http.get_text(api_base + '/repos/$owner/$repo/pulls/$target')) or {
			eprintln('fatal: error while parsing GitHub response: $err')
			exit(1)
		}
		submitter := data.as_map()['user'] ?.as_map()['login'] ? as string
		source_branch := data.as_map()['head'] ?.as_map()['ref'] ? as string
		ensure_remote(submitter, repo)
		ensure_command('git fetch $submitter')
		ensure_command('git checkout -b $target --track $submitter/$source_branch')
		exit(os.system('git pull'))
	} else {
		slug := target.split('/')
		if slug.len != 2 {
			eprintln('fatal: invalid target')
			exit(2)
		}
		ensure_remote(slug[0], repo)
		ensure_command('git fetch ${slug[0]}')
		ensure_command('git checkout -b $target --track ${slug[0]}/${slug[1]}')
		exit(os.system('git pull'))
	}
}
