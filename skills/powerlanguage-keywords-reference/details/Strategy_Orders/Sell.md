# Sell

**Category:** Strategy_Orders
**Signature:** ``

Closes part or all of any open long entries per the given parameters.

**Parameters**
- `ExitLabel` *(string, optional)* ??assigns a name that will be ??see official docs
- `EntryLabel` *(numeric, optional)* ??ties the exit to the particular ??see official docs
- `Exit` *(numeric, required)* ??specifies the timing and price of ??see official docs

**Example (illustrative)**
```
Sell ( "Sell_Demo" ) 1 Contract Next Bar Market;
```

*Official docs:* https://www.multicharts.com/trading-software/index.php?title=Sell
