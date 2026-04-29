# Updated Design Class Diagrams
> Replace the corresponding diagrams on pages 40–42 of the paper with the ones below.
> Render with any Mermaid-compatible tool (e.g. mermaid.live, VS Code Mermaid Preview, or Notion).

---

## 5.1 User Management

```mermaid
classDiagram
    class Profile {
        profileID PK : integer
        userID FK : string
        username : string
        roleID FK : integer
        name : string
        phone : string
        profilePicture : string
        addressStreet : string
        addressBarangay : string
        addressCity : string
        addressProvince : string
        addressRegion : string
        addressPostalCode : string
        addressCountry : string
        isActive : boolean
        createdAt : timestamp
        updatedAt : timestamp
    }

    class UserRole {
        roleID PK : integer
        roleName : string
        createdAt : timestamp
    }

    class Login_History {
        loginID PK : integer
        profileID FK : integer
        username : string
        loginTime : timestamp
        logoutTime : timestamp
        createdAt : timestamp
    }

    UserRole "1" --> "0..*" Profile : defines role of
    Profile "1" --> "0..*" Login_History : has
```

---

## 5.2 Product Management

```mermaid
classDiagram
    class Product {
        productID PK : integer
        productName : string
        description : string
        categoryID FK : integer
        purchasePrice : float
        sellingPrice : float
        perishable : boolean
        sku : string
        supplier : string
        expiryDate : date
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Product_Category {
        categoryID PK : integer
        categoryName : string
        createdAt : timestamp
    }

    class Service_Supply {
        serviceSupplyID PK : integer
        serviceSupplyName : string
        supplyType : string
        paperSize : string
        purchasePrice : float
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Print_Service {
        printServiceID PK : integer
        name : string
        description : string
        paperSizeID FK : integer
        colorModeID FK : integer
        orientationID FK : integer
        finishID FK : integer
        basePrice : float
        inkCostPerPage : float
        paperCostPerPage : float
        electricityCostPerPage : float
        maintenanceCostPerPage : float
        totalCostPerPage : float
        paperStock : float
        inkLevel : float
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Machine {
        machineID PK : integer
        printServiceID FK : integer
        machineName : string
        isActive : boolean
        createdAt : timestamp
        updatedAt : timestamp
    }

    Product_Category "1" --> "0..*" Product : categorizes
    Print_Service "1" --> "0..*" Machine : uses
    Service_Supply "0..*" ..> Print_Service : consumed by
```

---

## 5.3 Inventory Management

```mermaid
classDiagram
    class Inventory_Item {
        inventoryItemID PK : integer
        productID FK : integer
        stockInID FK : integer
        stock : float
        retailPrice : float
        reorderLevel : float
        location : string
        lastRestocked : timestamp
        expiryDate : date
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Stock_In {
        stockInID PK : integer
        productID FK : integer
        serviceSupplyID FK : integer
        userID FK : integer
        expenseID FK : integer
        purchasePrice : float
        quantityAdded : float
        expiryDate : date
        stockInDate : timestamp
        createdAt : timestamp
    }

    class Stock_Out {
        stockOutID PK : integer
        transactionID FK : integer
        transactionItemID FK : integer
        productID FK : integer
        serviceSupplyID FK : integer
        inventoryItemID FK : integer
        userID FK : integer
        quantityRemoved : float
        stockOutType : string
        stockOutDate : timestamp
        createdAt : timestamp
    }

    Stock_In "1" --> "0..*" Inventory_Item : restocks
    Inventory_Item "1" --> "0..*" Stock_Out : depleted by
```

---

## 5.4 Transaction Sales

```mermaid
classDiagram
    class Customer {
        customerID PK : integer
        name : string
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Transaction {
        transactionID PK : integer
        transactionNumber : string
        cashierID FK : integer
        customerID FK : integer
        paymentMethodID FK : integer
        statusID FK : integer
        subtotal : float
        tax : float
        discount : float
        total : float
        storeRevenue : float
        printingRevenue : float
        totalCost : float
        grossProfit : float
        notes : string
        date : timestamp
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Transaction_Item {
        transactionItemID PK : integer
        transactionID FK : integer
        productID FK : integer
        inventoryID FK : integer
        printOrderID FK : integer
        categoryID FK : integer
        productName : string
        quantity : float
        unitPrice : float
        discount : float
        itemCost : float
        subtotal : float
        createdAt : timestamp
        updatedAt : timestamp
    }

    class Print_Order {
        printOrderID PK : integer
        printServiceID FK : integer
        quantity : integer
        copies : integer
        doubleSided : boolean
        additionalFinishID FK : integer
        totalPrice : float
        inkUsed : float
        paperUsed : float
        electricityUsed : float
        totalCost : float
        profitMargin : float
        createdAt : timestamp
        updatedAt : timestamp
    }

    Customer "0..1" --> "0..*" Transaction : places
    Transaction "1" --> "0..*" Transaction_Item : contains
    Transaction_Item "0..1" --> "0..1" Print_Order : references
```
