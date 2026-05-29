# BuyToCover

**Category:** Strategy_Orders
**Signature:** `BuyToCover[("ExitLabel")][From Entry("EntryLabel")][TradeSize[Total]]Exit`

Closes part or all of any open short entries per the given parameters.

**Parameters**
- `ExitLabel` *(string, optional)* ??assigns a name that will be ??see official docs
- `EntryLabel` *(string, optional)* ??ties the exit to the particular ??see official docs
- `TradeSize` *(numeric, optional)* ??a numerical expression, specifying the number ??see official docs
- `Exit` *(numeric, required)* ??specifies the timing and price of ??see official docs

**Example (illustrative)**
```
BuyToCover ( "BuyToCover_Demo" ) 1 Contract Next Bar Market;
```

*Official docs:* https://www.multicharts.com/trading-software/index.php?title=BuyToCover
