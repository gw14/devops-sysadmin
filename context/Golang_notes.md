# Golang Study Notes

### 1. Capitalization & Exported Names

* **`Upper`** = Public/Exported (visible to other packages).
* **`lower`** = Private/Internal (visible only within the package).
* **Purpose**: In Go, capitalization is a functional requirement for visibility.

### 2. Package Access Syntax

* **`package.Function`** (e.g., `fmt.Println`).
* **`fmt`**: The Package 🏛️ | **`.`**: Access Operator 🚪 | **`Function`**: The Tool 🛠️

### 3. Essential Packages & Functions

* **Packages**:
* `fmt`: Formatting and printing to console.
* `math`: Basic constants and mathematical functions.


* **Functions**:
* `fmt.Println`: Print with newline.
* `fmt.Printf`: Formatted print using verbs (e.g., `%v`, `%T`).



### 4. Variable Declarations

* **`var`**: Used for explicit type declarations or package-level variables.
* **`:=`**: The **Walrus Operator**. Used inside functions for brevity; Go infers the type.

### 5. Functions: Organizing Flow & Multiple Returns

Functions prevent "spaghetti code" by turning logic into reusable tools.

* **Anatomy**: Defined by the `func` keyword, name, parameters, and return types.
* **Multiple Return Values**: List types in parentheses. Used to return data and an error simultaneously.
* **Error Handling**: Go returns values and errors instead of throwing exceptions. Always check `if err != nil`.
* **The Blank Identifier (`_`)**: Use this to ignore a returned value you don't need.

**Example:**

```go
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("cannot divide by zero")
    }
    return a / b, nil
}

```

### 6. Control Flow: If Statements

* **Syntax**: No `()`, mandatory `{}`.
* **The "Init" Statement**: `if val := 10; val > 5 { ... }` (variable is scoped only to this block).
* **Multi-branch Syntax**:

```go
if condition1 {
    // code
} else if condition2 {
    // code
} else {
    // code
}

```

### 7. Control Flow: Switch Statements

* **Rule**: No `break` needed; it breaks automatically after a match.
* **Multiple Values**: `case "Saturday", "Sunday":`.

### 8. Loops: The "For" Loop

Go uses only one keyword for all looping needs.

* **Standard**: `for i := 0; i < 10; i++ { ... }`
* **"While" Style**: `for condition { ... }`
* **Infinite**: `for { ... }`
* **Range**: The idiomatic way to iterate over collections. Returns `index, value`.

### 9. Loop Control: break and continue

* **`break`**: Exits the loop entirely.
* **`continue`**: Skips the current iteration and jumps to the next one.

### 10. Defer: The "Do This Later" Flow

* **Rule**: Schedules a function call to run immediately before the surrounding function returns.
* **Use Case**: Cleanup (closing files, unlocking resources). Executes in **LIFO** (Last-In-First-Out) order.

### 11. Arrays (Fixed Size)

* **Syntax**: `[size]type`.
* **Rule**: Size is part of the type and cannot be changed. Arrays are **value types** (copying an array copies all elements).
* **Example**: `primes := [...]int{2, 3, 5}`.

### 12. Slices (Dynamic Size)

* **Syntax**: `[]type`.
* **The `make` function**: `make([]type, length, capacity)`.
* **The Append Rule**: `append` returns a **new** slice header. You **must** assign it back to the variable: `s = append(s, elem)`.
* **Variadic Append**: `slice = append(slice1, slice2...)`.


* **Slicing**: `numbers[1:4]` (Includes index 1, excludes index 4).

### 13. Maps: Key-Value Collections

* **Syntax**: `map[KeyType]ValueType`.
* **Initialization**: Must use `make(map[string]int)` or a map literal.
* **The "Comma OK" Idiom**: Used to distinguish between a zero-value and a missing key.

```go
val, ok := m["key"]
if ok { /* exists */ }

```

### 14. Coding Idioms

* **The "Happy Path"**: Handle errors/unhappy cases early and return to avoid deep nesting ("Pyramid of Doom").

I have added the **Pointers** note to your master list, ensuring it follows your strict guidelines for code examples and articulated logic.

---

### 15. Pointers: Memory Addresses vs. Values

* **Code Example**:
```go
func main() {
    age := 25
    ptr := &age // & (Address of) gets the memory location

    fmt.Println(ptr)  // Prints address: 0xc000012088
    fmt.Println(*ptr) // * (Dereference) gets value at address: 25

    updateAge(&age)   // Passing the address, not a copy
    fmt.Println(age)  // Prints 26
}

func updateAge(a *int) {
    *a = *a + 1 // Modifies the original value at that memory address
}

```


* **Articulated Logic**:
* 
**Memory Efficiency**: Every variable is stored in RAM at a specific address; pointers allow you to store and pass that address rather than the actual data. 


* 
**The "Copy" Problem**: By default, Go is **"Pass by Value,"** meaning functions receive a complete copy of data. 


* 
**Persistent Mutation**: Passing a pointer is essential when you need a function to modify the original variable, as it avoids the overhead of copying and ensures changes persist outside the function's scope. 


* 
**Explicit Control**: Using `&` to find an address and `*` to "follow" it (dereferencing) gives the developer explicit control over memory usage, preventing accidental data mutations while allowing purposeful ones. 





---

Here is the new note for **Structs**, formatted to include a code example and articulated logic as per your guidelines.

### 16. Structs: Custom Data Types & Behavior

* **Code Example**:
```go
// 1. Define the Blueprint
type Task struct {
    Title    string
    Priority int
    IsDone   bool
}

// 2. Add Behavior with a Pointer Receiver
// Logic: (t *Task) allows the method to modify the original struct
func (t *Task) MarkAsDone() {
    t.IsDone = true 
}

func main() {
    // 3. Create an Instance
    myTask := Task{
        Title:    "Learn Structs",
        Priority: 1,
        IsDone:   false,
    }

    myTask.MarkAsDone() // Modifies myTask directly
}

```


* **Articulated Logic**:
* **Custom Modeling**: Structs allow you to group different data types (strings, ints, bools) into a single logical unit. This creates a "blueprint" for real-world objects, making code more organized than using loose, unrelated variables.
* **Encapsulated Behavior**: In Go, "Methods" are functions attached to a specific type. This allows you to keep the data (the fields) and the actions (the methods) together.
* **Pointer Receiver Rationale**: When a method needs to change a value inside the struct, you must use a **pointer receiver** (`*Task`). If you used a value receiver, Go would create a hidden copy of the struct; the method would change that copy, and the original `myTask` would remain unchanged.



---


