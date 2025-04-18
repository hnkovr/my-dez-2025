from pathlib import Path
import yaml, os
from fastcore.basics import store_attr
from dotenv import load_dotenv

class Config:
    def __init__(self, path='config.yaml'):
        load_dotenv()
        with open(path) as f:
            cfg = yaml.safe_load(f)
        store_attr('cfg')

    def __getitem__(self, key):
        return self.cfg.get(key)

config = Config()
