#!/usr/bin/env python

import salt.config
import salt.loader

import json
import json_delta

try:
    from colorama import Fore, Back, Style, init
    init()
except ImportError:  # fallback so that the imported classes always exist
    class ColorFallback():
        def __getattr__(self, name):
            return ''
    Fore = Back = Style = ColorFallback()


def color_diff(diff):
    """Colorize lines in the diff generator object"""

    for line in diff:
        if line.startswith('+'):
            yield Fore.GREEN + line + Fore.RESET
        elif line.startswith('-'):
            yield Fore.RED + line + Fore.RESET
        else:
            yield line


class Minion():

    default_config = '/opt/{name}/minion'

    def __init__(self, name=None, config=None, **salt_params):

        if not config:
            config = self.default_config.format(name=name)
        self.config = config

        self.salt_params = salt_params

        __opts__ = salt.config.minion_config(self.config)
        __grains__ = salt.loader.grains(__opts__)
        __opts__['grains'] = __grains__
        __utils__ = salt.loader.utils(__opts__)
        self.salt = salt.loader.minion_mods(__opts__, utils=__utils__)

    @property
    def highstate(self):
        return json.loads(json.dumps(self.salt['state.show_highstate'](**self.salt_params)))

    @property
    def pillar_items(self):
        return json.loads(json.dumps(self.salt['pillar.items'](**self.salt_params)))

    @property
    def grains_items(self):
        return json.loads(json.dumps(self.salt['grains.items']()))

    def __str__(self):
        return json.dumps(
            {
                "highstate": self.highstate,
                "pillar_items": self.pillar_items,
                "grains_items": self.grains_items,
            },
            indent=4
        )


def compare_minions(minionA, minionB):
    '''Generate colorized unified diff of two minions'''

    comparable_properties = [
        'highstate',
        'pillar_items',
        'grains_items',
    ]

    diffs = {}
    for key in comparable_properties:
        diffs[key] = color_diff(
            json_delta.udiff(
                getattr(minionA, key),
                getattr(minionB, key),
            )
        )

    result = "\n".join(
        [
            "\n".join(
                [key.upper(), "\n".join(value)]
            ) for key, value in diffs.items()
        ]
    )
    return result


if __name__ == "__main__":

    minionA = Minion('minionA')
    minionB = Minion('minionB')

    print compare_minions(minionA, minionB)
