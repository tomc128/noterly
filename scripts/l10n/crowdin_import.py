import os
import re
import zipfile

SOURCE_FILE = 'Noterly (Translations).zip'
FLUTTER_ARB_DIRECTORY = '../../noterly/lib/l10n/'

# this is in the format
# (filename, rename_file?, change_locale_field?)
# where rename_file? is False or the new filename
# and change_locale_field? is False or the new locale field in the arb file
LANGUAGE_RENAMES = [
    ('app_es.arb', False, 'es'),
    ('app_en-GB.arb', False, 'en_GB'),
    ('app_en-US.arb', False, 'en_US'),
    ('app_zh-CN.arb', False, 'zh_CN'),
    ('app_zh-HK.arb', False, 'zh_HK'),
    ('app_zh-MO.arb', False, 'zh_MO'),
]

source = SOURCE_FILE

if source == 'ask':
    source = input('Enter the path to the source file (.zip): ')

if not source.endswith('.zip'):
    print('Source file must be a .zip file')
    exit()

if not os.path.exists(source):
    print('Source file does not exist')
    exit()


# create the temp directory if it doesn't exist
if not os.path.exists('temp'):
    os.mkdir('temp')


# remove all files in the flutter directory
for file in os.listdir(FLUTTER_ARB_DIRECTORY):
    # exclude app.arb and localisations_util.dart
    if file != 'app.arb' and file != 'localisations_util.dart':
        os.remove(os.path.join(FLUTTER_ARB_DIRECTORY, file))


with zipfile.ZipFile(source, 'r') as zip_ref:
    zip_ref.extractall('temp')

# go into the temp directory, and for each subfolder, copy the file to the flutter directory
# taking notes of the language renames

for folder in os.listdir('temp'):
    if not os.path.isdir(os.path.join('temp', folder)):
        continue

    for file in os.listdir(os.path.join('temp', folder)):
        if not file.endswith('.arb'):
            continue

        should_rename = False
        
        for rename in LANGUAGE_RENAMES:
            if rename[0] == file:
                should_rename = rename
                break
        
        if should_rename:
            if should_rename[1]:
                os.rename(os.path.join('temp', folder, file), os.path.join('temp', folder, should_rename[1]))
                file = should_rename[1]
            
            if should_rename[2]:
                with open(os.path.join('temp', folder, file), 'r', encoding='utf-8') as f:
                    contents = f.read()
                
                # use regex to repalce the locale field 
                contents = re.sub(r'"@@locale": ".*"', f'"@@locale": "{should_rename[2]}"', contents)

                with open(os.path.join('temp', folder, file), 'w', encoding='utf-8') as f:
                    f.write(contents)
        
        # copy the file to the flutter directory, without the language subfolder
        os.rename(os.path.join('temp', folder, file), os.path.join(FLUTTER_ARB_DIRECTORY, file))

        # remove the temp subfolder
        os.rmdir(os.path.join('temp', folder))

