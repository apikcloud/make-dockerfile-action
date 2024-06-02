import os
from typing import List
import click
from jinja2 import Environment, FileSystemLoader

ADDONS_PATH = "/mnt/extra-addons"
SOURCES = [
    ["sys_packages", "packages.txt"],
    ["py_packages", "requirements.txt"],
]

DEV_PACKAGES = [
    "coverage",
    "websocket-client",
]


def extract_items(filepath: str) -> List:
    if not os.path.exists(filepath):
        return []

    with open(filepath, "r") as file:
        items = [item.strip() for item in file.readlines() if not item.startswith("#")]

    return items


def generate(
    base: str, workdir: str, dev: bool = False, force_upgrade: bool = True
) -> str:
    vals = {}
    # TODO: Use context path
    environment = Environment(loader=FileSystemLoader("/app/templates/"))
    template = environment.get_template("Dockerfile.jinja")

    for name, filename in SOURCES:
        filepath = os.path.join(workdir, filename)
        vals[name] = extract_items(filepath)

    return template.render(
        vals,
        base=base,
        dev=dev,
        force_upgrade=force_upgrade,
        dev_packages=DEV_PACKAGES,
        addons_path=ADDONS_PATH,
    )


@click.command()
@click.option("--dev", is_flag=True, default=False, help="Dev mode.")
@click.option(
    "--output", is_flag=True, default=False, help="Write content to filepath."
)
@click.option("--no-upgrade", is_flag=True, default=False, help="No pip upgrade.")
@click.option("--workdir", required=True, help="Working directory.")
@click.option("--base", required=True, help="Base image.")
@click.option("--filename", required=False, default="Dockerfile", help="Filename.")
def main(workdir, base, output, filename, dev, no_upgrade) -> None:
    """Generate Dockerfile"""

    content = generate(base, workdir, dev, force_upgrade=not no_upgrade)

    if output:
        with open(os.path.join(workdir, filename), mode="w+") as file:
            file.write(content)
    else:
        print(content)


if __name__ == "__main__":
    main()
