import logging
import subprocess
import os
import os.path
import shlex
from email.utils import parsedate_to_datetime

CMD_GIT_GET_AFFECTED_FILES = "git diff-tree --no-commit-id --name-only -r %s %s"
CMD_GIT_GET_COMMIT_SHA = "git rev-parse %s"
CMD_GIT_GET_COMMITTER = "git --no-pager show -s --format='%%an <%%ae>; %%cD' %s"
CMD_GIT_GET_DIFF = 'git diff %s %s %s'

LOCKED_FILES = [
    # dialer for iOS
    'TouchPalDialerLaunch.m',
    'TouchPalDialerAppDelegate.m',

    # dialer for Android
    'TMainSlide.java',
    'TPBaseActivity.java',
    'TStartup.java',
    'StartupStuff.java',
]


def git_for_path(git_path):
    def wrapper(func):
        def wrapped(*args, **kwargs):
            cwd = os.getcwd()
            os.chdir(git_path)
            ret = func(*args, **kwargs)
            os.chdir(cwd)
            return ret

        return wrapped

    return wrapper


def get_output_from_cmd(raw_cmd):
    args = shlex.split(raw_cmd)
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = p.communicate()
    if err:
        logging.error('command (%s) failed with error: %s' % (raw_cmd, err))
        raise Exception('command error')
    else:
        return out.decode()  # bytes -> str


def get_changed_files(tree1, tree2):
    global CMD_GIT_GET_AFFECTED_FILES
    output = get_output_from_cmd(CMD_GIT_GET_AFFECTED_FILES % (tree1, tree2))
    return output.split()


def get_sha_for_commit(commit):
    global CMD_GIT_GET_COMMIT_SHA
    full_sha = get_output_from_cmd(CMD_GIT_GET_COMMIT_SHA % commit)
    return full_sha[:7]  # git works for first 7 chars


def get_commit_info(commit):
    global CMD_GIT_GET_COMMITTER
    result = get_output_from_cmd(CMD_GIT_GET_COMMITTER % commit)
    user, commit_time = result.split(';')
    return user, parsedate_to_datetime(commit_time)


def get_diff(commit1, commit2, file_list):
    global CMD_GIT_GET_DIFF
    diff = get_output_from_cmd(
        CMD_GIT_GET_DIFF % (commit1, commit2, ' '.join(file_list)))
    return diff


def get_commit_info_with_diff(commit1, commit2, file_list):
    sha1 = get_sha_for_commit(commit1)
    sha2 = get_sha_for_commit(commit2)
    user1, commit_time1 = get_commit_info(sha1)
    user2, commit_time2 = get_commit_info(sha2)
    if commit_time1 < commit_time2:
        return ('%s <%s>' % (commit2, sha2),
                user2,
                commit_time2,
                get_diff(sha1, sha2, file_list))
    return ('%s <%s>' % (commit1, sha1),
            user1,
            commit_time1,
            get_diff(sha2, sha1, file_list))


def validate(git_repo_path, tree1, tree2, output):
    report = []
    global LOCKED_FILES

    wrapper = git_for_path(git_repo_path)
    changed_files = wrapper(get_changed_files)(tree1, tree2)
    files = []
    for file_name in LOCKED_FILES:
        for captured_file in changed_files:
            if captured_file.endswith(file_name):
                files.append(captured_file)
                break

    if files:
        report.append(
            'Below locked files have been modified between %s and %s:' %
            (tree1, tree2)
        )
        report.extend(files)
        commit, user, commit_time, diff = \
            wrapper(get_commit_info_with_diff)(tree1, tree2, files)
        report.append('\nThis commit (%s) was committed by %s at %s.' %
                      (commit, user, commit_time))
        report.append('\n\n')
        report.append('=' * 80)
        report.append(diff)

    with open(output, 'w') as fh:
        fh.write('\n'.join(report))


if __name__ == '__main__':
    import sys

    if len(sys.argv) >= 5:
        path, git_tree1, git_tree2, result_file = sys.argv[1:5]
        validate(path, git_tree1, git_tree2, result_file)
