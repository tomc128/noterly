import json

import gspread

gc = gspread.service_account(filename='./credentials.json')

sheet = gc.open_by_key('1c0I6lARH-S2x8sxpA2nQ1gZZm4Q6b5OyuPjVvjuvF94').worksheet('Translations')


# the output for the program should be a json file for each language.
# each json file should look like the following example
# en_GB.json:
# { "key": "translation", "key2": "translation2", ... }


# Get all the data from the sheet
data = sheet.get_values()

# Get the languages
languages = [lang for lang in data[0][1:] if lang.strip() != '']

# Get the keys
keys = [key[0] for key in data[1:] if key[0].strip() != '' and not key[0].strip().startswith('_') and not key[0].strip().startswith('$') ]


# Create a dictionary for each language
for lang in languages:
    lang_dict = {}
    for key in keys:
        for row in data[1:]:
            if row[0] == key:
                translation = row[languages.index(lang)+1].strip()
                if translation:
                    lang_dict[key] = translation

    with open(f'./new_out/{lang}.json', 'w', encoding='utf-8') as f:
        f.write(json.dumps(lang_dict))
