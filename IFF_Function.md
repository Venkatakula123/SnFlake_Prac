# Snowflake `IFF` Function

`IFF` evaluates a condition and returns one value when it is true and another when it is false.

## Syntax

```sql
IFF(condition, value_if_true, value_if_false)
```

- `condition`: expression to evaluate.
- `value_if_true`: value returned when the condition is true.
- `value_if_false`: value returned when the condition is false or `NULL`.

## Example

Label a sale as belonging to Q1 or another quarter:

```sql
SELECT IFF(QUARTER(SALES_DATE) = 1, 'Q1', 'Other') AS QUARTER_LABEL
FROM QUARTERLY_SALES;
```

`IFF` is also useful for conditional aggregation. This sums sales for Q1 and returns `0` for rows from other quarters:

```sql
SUM(IFF(QUARTER(SALES_DATE) = 1, SALES, 0)) AS Q1
```

`IFF` is similar to a ternary operator in many programming languages:

```text
condition ? value_if_true : value_if_false
```

## Notes

- `IFF` takes exactly three arguments.
- If the condition evaluates to `NULL`, `IFF` returns `value_if_false`.
- For multiple conditions or more complex branching, use `CASE`.
