import json

# If set to True, keys will be converted to nested dictionaries
# i.e., a.b.c will be converted to {a: {b: {c: "value"}}}
# The current implementation of the conversion does not work with
# keys such as: key.a = "value" and key.a.b = "value". It will
# ignore the first key. Therefore, this is disabled until a better
# implementation is found.
USE_NESTING = False

# If set to True, the output will be also saved into the Flutter
# project directory.
SAVE_TO_FLUTTER = True


def create_nested_dict(key_parts, value, d):
    if type(d) != dict:
        d = {}
    if len(key_parts) == 1:
        d[key_parts[0]] = value
        return d
    if key_parts[0] not in d:
        d[key_parts[0]] = {}
    d[key_parts[0]] = create_nested_dict(key_parts[1:], value, d[key_parts[0]])
    return d

with open('i18n.json', 'r', encoding='utf-8') as f:
    i18n = json.load(f)

lang_data = {}

for key, value in i18n['text'].items():
    for lang, text in value.items():
        if lang not in lang_data:
            lang_data[lang] = {}

        if USE_NESTING:
            key_parts = key.split(".")
            lang_data[lang] = create_nested_dict(key_parts, text, lang_data[lang])
        else:        
            lang_data[lang][key] = text

for lang, data in lang_data.items():
    with open(f'out/{lang}.json', 'w', encoding='utf-8') as f:
        json.dump(data, f)
    
    if SAVE_TO_FLUTTER:
        with open(f'../../noterly/assets/i18n/{lang}.json', 'w', encoding='utf-8') as f:
            json.dump(data, f)
