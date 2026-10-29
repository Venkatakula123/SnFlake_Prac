# Snowflake `DECODE` Function

`DECODE` compares an expression with search values and returns the result for the first match.

## Syntax

```sql
DECODE(expression, search1, result1 [, search2, result2, ...] [, default])
```

- `expression`: value to compare.
- `search`: value to match against the expression.
- `result`: value returned for a match.
- `default`: value returned when nothing matches. If omitted, the result is `NULL`.

## Example

Map a quarter number to a label:

```sql
SELECT DECODE(
    QUARTER(SALES_DATE),
    1, 'Q1',
    2, 'Q2',
    3, 'Q3',
    4, 'Q4',
    'Unknown'
) AS QUARTER_LABEL
FROM QUARTERLY_SALES;
```

`DECODE` also supports conditional aggregation. This sums sales for Q1 and returns `0` for rows from other quarters:

```sql
SUM(DECODE(QUARTER(SALES_DATE), 1, SALES, 0)) AS Q1
```

That call has four arguments: the expression, the value to match, the result for a match, and the default result.

## Notes

- `DECODE` checks search values in order and returns the result for the first match.
- In Snowflake, `DECODE` treats `NULL` as equal to `NULL` when matching.
- For more complex conditions or ranges, use `CASE` instead.
