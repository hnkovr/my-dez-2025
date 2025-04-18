import click
from src.logger import get_logger
from src.conf import config

log = get_logger()

@click.group()
def cli():
    pass

@cli.command()
def hello():
    log.info("✅ Hello from CLI")
    click.echo("Config project: " + config['project'])

if __name__ == '__main__':
    cli()
