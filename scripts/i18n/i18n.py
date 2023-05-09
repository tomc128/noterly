import json
import os
import shutil

import gspread
from rich import print

# The directory to save the parsed language files to.
OUTPUT_DIRECTORY = './new_out'

# The directory to save the parsed language files to in the Flutter project,
# if SAVE_TO_FLUTTER is set to True.
FLUTTER_OUTPUT_DIRECTORY = '../../noterly/assets/i18n'

# If set to True, the output will be also saved directly into the
# Flutter project directory as well as the output directory.
SAVE_TO_FLUTTER = True

# If set to True, the output directory will be purged before
# generating the new files. This helps to remove any old files
# that are no longer needed.
PURGE_DIRECTORY = True

# If set to True, the "$include" key will be used to determine
# which languages to include in the output.
PARSE_INCLUDE = True

print('[blue]Loading spreadsheet...[/blue]', end='')
gc = gspread.service_account(filename='./credentials.json')
sheet = gc.open_by_key('1c0I6lARH-S2x8sxpA2nQ1gZZm4Q6b5OyuPjVvjuvF94').worksheet('Translations')
print(' [bold green]Done![/bold green]')

print('[blue]Loading data...[/blue]', end='')
data = sheet.get_values()
print(' [bold green]Done![/bold green]')

languages = [lang for lang in data[0][1:] if lang.strip() != '']

translation_keys = [key[0] for key in data[1:] if
                        key[0].strip() != '' and
                        not key[0].strip().startswith('_') and
                        not key[0].strip().startswith('$')]

if PURGE_DIRECTORY:
    if os.path.exists(OUTPUT_DIRECTORY):
        shutil.rmtree(OUTPUT_DIRECTORY)
    os.mkdir(OUTPUT_DIRECTORY)

    if SAVE_TO_FLUTTER:
        if os.path.exists(FLUTTER_OUTPUT_DIRECTORY):
            shutil.rmtree(FLUTTER_OUTPUT_DIRECTORY)
        os.mkdir(FLUTTER_OUTPUT_DIRECTORY)


# Create a dictionary for each language
for lang in languages:
    if PARSE_INCLUDE:
        included = data[1][languages.index(lang)+1].strip() == 'TRUE'
        if not included:
            print(f'[yellow]Skipping {lang}[/yellow]')
            continue

    print(f'[blue]Parsing {lang}...[blue]', end='')

    lang_dict = {}
    for key in translation_keys:
        for row in data[1:]:
            if row[0] == key:
                translation = row[languages.index(lang)+1].strip()
                if translation:
                    lang_dict[key] = translation

    with open(f'{OUTPUT_DIRECTORY}/{lang}.json', 'w', encoding='utf-8') as f:
        json.dump(lang_dict, f)
    
    if SAVE_TO_FLUTTER:
        with open(f'{FLUTTER_OUTPUT_DIRECTORY}/{lang}.json', 'w', encoding='utf-8') as f:
            json.dump(lang_dict, f)

    print(' [green bold]Done![/green bold]')
