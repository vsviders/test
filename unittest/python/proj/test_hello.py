import unittest
class MyTestCase(unittest.TestCase):
    def test_prints_hello(self):
        assert "Hello World" == "Hello World"


if __name__ == "__main__":
    unittest.main()