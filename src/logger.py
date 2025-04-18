import logging
import sys

class Logger(logging.Formatter):
    FORMATS = {
        ##
        # logging.DEBUG:    "\033[2m%(asctime)s 🐛 DEBUG    %(message)s\033[0m",
        # logging.INFO:     "\033[36m%(asctime)s ℹ️  INFO     %(message)s\033[0m",
        # logging.WARNING:  "\033[33m%(asctime)s ⚠️  WARNING  %(message)s\033[0m",
        # logging.ERROR:    "\033[31m%(asctime)s 🔥 ERROR    %(message)s\033[0m",
        # logging.CRITICAL: "\033[1;41m%(asctime)s 💥 CRITICAL %(message)s\033[0m",
        logging.DEBUG:    "\033[2m%(asctime)s 🐛 %(message)s\033[0m",
        logging.INFO:     "\033[36m%(asctime)s ℹ️ %(message)s\033[0m",
        logging.WARNING:  "\033[33m%(asctime)s ⚠️ %(message)s\033[0m",
        logging.ERROR:    "\033[31m%(asctime)s 🔥 %(message)s\033[0m",
        logging.CRITICAL: "\033[1;41m%(asctime)s 💥 %(message)s\033[0m",
    }

    def format(self, record):
        log_fmt = self.FORMATS.get(record.levelno)
        formatter = logging.Formatter(log_fmt, "%y/%m/%d %H:%M:%S")
        return formatter.format(record)

def get_logger(name="app") -> logging.Logger:
    logger = logging.getLogger(name)
    if not logger.hasHandlers():
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(Logger())
        logger.addHandler(handler)
        logger.setLevel(logging.DEBUG)
    return logger

def demo():
    from src.logger import get_logger

    log = get_logger("test")

    log.debug("Техническая информация")
    log.info("Система запущена")
    log.warning("Почти ошибка")
    log.error("Что-то пошло не так")
    log.critical("ВСЁ УПАЛО!")

if __name__ == '__main__':
    demo()