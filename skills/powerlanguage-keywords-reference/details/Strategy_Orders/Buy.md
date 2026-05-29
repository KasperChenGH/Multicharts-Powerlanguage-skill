# Buy

**Category:** Strategy_Orders
**Signature:** `Buy[("EntryLabel")][TradeSize]EntryType;`

Opens a long position with the size and timing given by the parameters.

**Parameters**
- `EntryLabel` *(string, optional)* — see official docs
- `TradeSize` *(numeric, optional)* — see official docs
- `EntryType` *(numeric, required)* — see official docs

**Example (illustrative)**
```
Buy ( "Buy_Demo" ) 1 Contract Next Bar Market;
```

*Official docs:* https://www.multicharts.com/trading-software/index.php?title=Buy
