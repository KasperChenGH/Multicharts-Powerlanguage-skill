# Buy

**Category:** Strategy_Orders
**Signature:** `Buy[("EntryLabel")][TradeSize]EntryType;`

Opens a long position with the size and timing given by the parameters.

**Parameters**
- `EntryLabel` *(string, optional)* ??assigns a name that will be ??see official docs
- `TradeSize` *(numeric, optional)* ??a numerical expression, specifying the number ??see official docs
- `EntryType` *(numeric, required)* ??specifies the timing and price of ??see official docs

**Example (illustrative)**
```
Buy ( "Buy_Demo" ) 1 Contract Next Bar Market;
```

*Official docs:* https://www.multicharts.com/trading-software/index.php?title=Buy
