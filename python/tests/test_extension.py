import pyarrow as pa
import pytest
from NanobindExample import echo, my_function, square_array, sum, table_function


def test_sum() -> None:
    result = sum([1.0, 2.0])
    assert result == 3.0


def test_my_function() -> None:
    result = my_function(2, 1.5)
    assert result == 3.0


def test_double_array() -> None:
    arr = pa.array([1.0, 2.0, 3.0, 4.0])
    squared = square_array(arr)
    assert squared.to_pylist() == [1.0, 4.0, 9.0, 16.0]


def test_table() -> None:
    n_legs = pa.array([2, 4, 5, 100])
    animals = pa.array(["Flamingo", "Horse", "Brittle stars", "Centipede"])
    names = ["n_legs", "animals"]
    table = pa.Table.from_arrays([n_legs, animals], names=names)
    table_function(table)


def test_echo(caplog: pytest.LogCaptureFixture) -> None:
    echo()
    assert "Test message from bindings" in caplog.text


if __name__ == "__main__":
    pytest.main([__file__])
