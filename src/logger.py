import logging

FORMAT = "%(asctime)s 🐍 %(levelname)s %(message)s"
logging.basicConfig(format=FORMAT, level=logging.INFO, datefmt="%y/%m/%d %H:%M:%S")

def get_logger(name="app"):
    return logging.getLogger(name)
