# a space-separated list of directories to check
src_dirs = assignment
project_dirs = project
all_dirs = $(src_dirs) $(project_dirs)
githooks_dir = .githooks

help:
	@echo "format - format Python code with isort/Black"
	@echo "lint - check style with pylint"
	@echo "mypy - run the static type checker"
	@echo "check - run all static checks and analyzers"
	@echo "commitlint - run the git hooks"
	@echo "clean-pyc - remove Python file artifacts"
	@echo "clean-test - remove test and coverage artifacts"

gitsetup:
	git config core.hooksPath $(githooks_dir)

format:
	poetry run isort $(all_dirs)
	poetry run black $(all_dirs)
lint:
	mkdir -p reports
	poetry run pylint $(all_dirs)

flake8:
	poetry run flake8 $(all_dirs)

mypy:
	poetry run mypy $(src_dirs)

check-isort:
	poetry run isort --check $(all_dirs)

check-black:
	poetry run black --check $(all_dirs)

check: lint mypy flake8
	poetry run isort --check $(all_dirs)
	poetry run black --check $(all_dirs)

commitlint:
	bash $(githooks_dir)/pre-push
	poetry run python $(githooks_dir)/commit-msg

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	find . -name '.pytest_cache' -exec rm -fr {} +
	find . -name '.mypy_cache' -exec rm -fr {} +

clean-test:
	rm -f .coverage
	rm -f coverage.xml
	rm -fr reports/
	rm -fr htmlcov

clean: clean-pyc clean-test

.PHONY: install
install: install-poetry install-kernel poetry-install

.PHONY: install-poetry
install-poetry:
	@echo "Installing Poetry..."
	pip install poetry
    
.PHONY: install-kernel
install-kernel:
	@echo "Installing Poetry Kernel..."
	pip3 install --user poetry-kernel
    
.PHONY: poetry-install
poetry-install:
	@echo "Installing project dependencies with Poetry..."
	poetry install 
