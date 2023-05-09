# check that all the files in ./new_out are idential to the files in ./out

import filecmp
import os
import sys

dir_1 = './out'
dir_2 = './new_out'

def check_files(dir_1, dir_2):
    files_1 = os.listdir(dir_1)
    files_2 = os.listdir(dir_2)

    if len(files_1) != len(files_2):
        print('Files in the directories are not the same')
        return False

    for file in files_1:
        if file not in files_2:
            print(f'{file} not found in {dir_2}')
            return False

        if not filecmp.cmp(f'{dir_1}/{file}', f'{dir_2}/{file}'):
            print(f'{file} is not identical in both directories')
            return False

    return True

if __name__ == '__main__':
    if check_files(dir_1, dir_2):
        print('Files are identical')
        sys.exit(0)
    else:
        print('Files are not identical')
        sys.exit(1)