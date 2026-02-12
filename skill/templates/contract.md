# Contract: [Feature Name]

**Version**: 1.0
**Created**: YYYY-MM-DD

## 1. Overview

[Brief description of what this feature does. 1-2 paragraphs.]

## 2. Interface

### 2.1 [functionName]

```
functionName(param1: Type, param2: Type) -> ReturnType
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| param1 | Type | Yes | Description |
| param2 | Type | No | Description, default: X |

**Returns:** `ReturnType` - Description of what is returned

**Behavior:**
1. [Step-by-step what happens]
2. [Be specific about observable behavior]

**Errors:**
- `ErrorType1`: Thrown when [condition]
- `ErrorType2`: Thrown when [condition]

**Edge Cases:**
- When param1 is empty: [behavior]
- When param2 is null: [behavior]

### 2.2 [anotherFunction]

[Same structure as above]

## 3. Data Types

### 3.1 [TypeName]

```
{
  id: string           // Unique identifier
  field1: Type         // Description
  field2?: Type        // Optional, description
  createdAt: string    // ISO 8601 timestamp
}
```

**Invariants:**
- id is never empty
- createdAt is always a valid timestamp

## 4. Error Types

### 4.1 [ErrorType1]

**Thrown when:** [Specific condition]

**Shape:**
```
{
  type: "ErrorType1"
  message: string
  [additional fields]
}
```

## 5. Examples

### 5.1 Success Case

**Input:**
```
functionName("valid", 123)
```

**Output:**
```
{ id: "abc", result: "success" }
```

### 5.2 Error Case

**Input:**
```
functionName("", 123)
```

**Output:**
```
ErrorType1: "param1 cannot be empty"
```

## 6. Non-Requirements

[Explicitly state what this contract does NOT cover]

- Does NOT specify internal implementation details
- Does NOT guarantee specific performance characteristics
- Does NOT cover [out of scope item]

---

<!--
CONTRACT WRITING TIPS:

1. Be specific enough to test, vague enough to implement
   - Specify WHAT, not HOW
   - Define observable behavior, not algorithms

2. Include all error conditions
   - When is each error thrown?
   - What information does each error contain?

3. Define edge cases
   - Empty inputs, null values, boundary conditions
   - Tester needs to know what to verify

4. Provide examples
   - Clarify ambiguous requirements
   - Show both success and error cases

5. Use precise language
   - "MUST" / "SHALL" = mandatory
   - "SHOULD" = recommended
   - "MAY" = optional
-->
