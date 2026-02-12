# Contract: Example

**Version**: 1.0

## 1. Overview

This is an example contract. Replace with your actual feature specification.

## 2. Interface

### 2.1 exampleFunction

```
exampleFunction(input: string) -> Result
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| input | string | Yes | The input to process |

**Returns:** `Result` object with `success` boolean and `data` string

**Errors:**
- `InvalidInputError`: Thrown when input is empty

**Edge Cases:**
- When input is empty string: throws InvalidInputError
