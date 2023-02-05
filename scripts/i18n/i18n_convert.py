import json


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

with open('i18n.json', 'r') as f:
    i18n = json.load(f)

lang_data = {}

for key, value in i18n['text'].items():
    for lang, text in value.items():
        if lang not in lang_data:
            lang_data[lang] = {}
        key_parts = key.split(".")
        lang_data[lang] = create_nested_dict(key_parts, text, lang_data[lang])

for lang, data in lang_data.items():
    with open(f'out/{lang}.json', 'w') as f:
        json.dump(data, f)
