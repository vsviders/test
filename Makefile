# $Id$
#
# Makefile for the updater project - Python Development

BRANCH ?= python3.12_development
PYTHON := python3
PIP := $(PYTHON) -m pip
VENV := .venv
SRC_DIR := src/python
UNITTEST_DIR := unittest/python
TEST_DIR := unittest/python
TEST_ENV := PRODROOT=$(CURDIR) \
            PYTHONPATH=$(CURDIR)/src/python \
            CONFROOT=/usr/local/etc/updater
DOCS_DIR := doc

.PHONY: all help build buildpython setup clean clean-all \
        install install-dev venv \
        format format-check lint  \
        type-check test test-verbose test-coverage security \
        check docs docs-serve \
        clean-pyc clean-build clean-test

.DEFAULT_GOAL := help

help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

all: build

build: buildpython

buildpython:
	@src/python/shared/util/compiler.py .

## Configure updater project
setup:
	@bin/updater-configure.sh

## venv: Create virtual environment
venv:
	@$(PYTHON) -m venv $(VENV) && \
		echo "To activate in your terminal, run: source $(VENV)/bin/activate" 

install:
	@$(PIP) install --upgrade autopep8 mypy
	@[ -f requirements-dev.txt ] && $(PIP) install -r requirements-dev.txt || true

    
## install-dev: Install development dependencies
install-dev:
	@$(PIP) install --upgrade black isort flake8 pylint ruff \
		mypy types-requests types-PyYAML \
		pytest pytest-cov pytest-mock pytest-xdist bandit \
		sphinx sphinx-rtd-theme autopep8
	@[ -f requirements-dev.txt ] && $(PIP) install -r requirements-dev.txt || true

## format: Format code with autopep8 and isort
format:
	@$(PYTHON) -m autopep8 --in-place --recursive $(SRC_DIR) $(TEST_DIR)
	@$(PYTHON) -m isort $(SRC_DIR) $(TEST_DIR)

## format-check: Check code formatting without changes
format-check:
	@$(PYTHON) -m autopep8 --diff --recursive $(SRC_DIR) $(TEST_DIR)
	@$(PYTHON) -m isort --check-only --diff $(SRC_DIR) $(TEST_DIR)

## format-changed: Format files changed vs specified branch
format-changed:
	@git diff --name-only $(BRANCH) | grep '\.py$$' | xargs -r $(PYTHON) -m autopep8 --in-place --recursive
	@git diff --name-only $(BRANCH) | grep '\.py$$' | xargs -r $(PYTHON) -m isort

lint:
	@$(PYTHON) -m pylint $(SRC_DIR)
	@$(PYTHON) -m pylint $(UNITTEST_DIR)

## type-check: Run mypy type checker
type-check:
	@$(PYTHON) -m mypy $(SRC_DIR) \
		--exclude='/(\.venv|build|dist)/' \
		--ignore-missing-imports \
		--no-strict-optional

## security: Run bandit security scanner
security:
	@$(PYTHON) -m bandit -r $(SRC_DIR) -ll -x $(SRC_DIR)/**/tests/

## test: Run tests with pytest
test:
	@$(TEST_ENV) $(PYTHON) -m pytest $(TEST_DIR) -v --no-cov

## test-verbose: Run tests with detailed output
test-verbose:
	@$(TEST_ENV) $(PYTHON) -m pytest $(TEST_DIR) -vv -s

## test-coverage: Run tests with coverage report
test-coverage:
	@(TEST_ENV) $(PYTHON) -m pytest $(TEST_DIR) \
		--cov=$(SRC_DIR) \
		--cov-report=html \
		--cov-report=term \
		--cov-report=xml

## check: Run format-check, lint, and type-check
check: format-check lint type-check test security

## docs: Build Sphinx documentation
docs:
	@cd $(DOCS_DIR) && $(MAKE) html

## docs-serve: Build and serve documentation at localhost:8000
docs-serve: docs
	@cd $(DOCS_DIR)/_build/html && $(PYTHON) -m http.server 8000

## clean: Remove Python artifacts
clean: clean-pyc clean-build clean-test

clean-pyc:
	@find . -type f -name "*.pyc" -delete
	@find . -type f -name "*.pyo" -delete
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

clean-build:
	@rm -rf build/ dist/ .eggs/
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true

clean-test:
	@rm -rf .pytest_cache/ .coverage htmlcov/ .mypy_cache/ .ruff_cache/
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true

# EOF
