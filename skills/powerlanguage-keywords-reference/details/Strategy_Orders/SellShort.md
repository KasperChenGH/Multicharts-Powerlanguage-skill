# SellShort

**Category:** Strategy_Orders
**Signature:** `SellShort[("EntryLabel")][TradeSize]Entry`

Opens a short position with the size and timing given by the parameters.

**Parameters**
- `EntryLabel` *(string, optional)* — see official docs
- `TradeSize` *(numeric, optional)* — see official docs
- `Entry` *(numeric, required)* — see official docs

**Example (illustrative)**
```
SellShort ( "SellShort_Demo" ) 1 Contract Next Bar Market;
```

*Official docs:* https://www.multicharts.com/trading-software/index.php?title=SellShort
