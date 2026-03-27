"""Tests for the hello-world application module."""

import importlib
import io
import sys
import unittest
from contextlib import redirect_stdout


class MyTestCase(unittest.TestCase):
    """Test behavior of the hello-world application."""

    def test_import_prints_hello_world(self):
        """Importing proj.main should print Hello World once."""
        sys.modules.pop("proj.main", None)

        output = io.StringIO()
        with redirect_stdout(output):
            importlib.import_module("proj.main")

        self.assertEqual(output.getvalue().strip(), "Hello World")


if __name__ == "__main__":
    unittest.main()
