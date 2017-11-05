[Home](https://diamondmvc.github.io/Diamond/) | [Download](https://diamondmvc.github.io/Diamond/download) | [Documentation](https://diamondmvc.github.io/Diamond/docs) | [Tutorials](https://diamondmvc.github.io/Diamond/tutorials) | [Contributing](https://diamondmvc.github.io/Diamond/contributing)

<br>

# Snapshot-types

Snapshot types can keep track of a type's value history. They're only usable with value-types, because they can't do nested tracking.

Example:
```
import diamond.data;

auto value = new Snapshot!int;

value = 100;
value = 200;
value = 300;
value = 400;

import std.stdio : writefln;
writefln("%d %d %d %d %d", value[0], value[1], value[2], value[3], value);

// Prints: 100 200 300 400 400
```

# Transactions

Transactions are essential to secure data transactions where invalid/incomplete data cannot be afforded when a commit fails.

A transaction is based on a snapshot-type which can be passed to it, in which the transaction will handle the commit.

## Example

Let's say we have this:

```
struct BankTransfer
{
	string from;
	string to;
	double money;
}

struct BankAccount
{
  string name;
  double money;
}
```

Without transactions, committing something like a transfer of *$100* from *Bob* to *Sally* is not fail-proof ex. if the commit to the database fails then the transfer never happens, but we might already have updated the bank account of *Bob* to reflect he transfered *$100* and thus he lost *$100* and *Sally* never got the *$100*.

With transactions doing a simple roll-back on both *Bob*'s bank account will fix the issue. Attempting to commit the transaction again may done, but isn't necessary as it could have happen due to some critical failure, in which you just want to make sure the commit didn't create any side-effects and in such situation, doing a roll-back only is preferred.

### Transaction Example

```
auto bob = new Snapshot!BankAccount(BankAccount("Bob", 200));
auto sally = new Snapshot!BankAccount(BankAccount("Sally", 0));

auto transaction = new Transaction!BankTransfer;
transaction.commit = (transfer)
{
    bob.money -= transfer.money;
    sally.money += transfer.money;
    
    UpdateBankAccount(bob);
    UpdateBankAccount(sally);
};
transaction.success = (transfer)
{
    import diamond.core.io;
    
    print("Successfully transferred $%d from %s to %s", transfer.money, transfer.from, transfer.to);
    print("Bob's money: %d", bob.money);
    print("Sally's money: %d", sally.money);
};
transaction.failure = (transfer, error, retries)
{
    bob.prev(); // Goes back to the previous state of Bob's bank account
    sally.prev(); // Goes back to the previous state of Sally's bank account
    
    return false; // We don't want to retry ...
};

auto transfer = new Snapshot!BankTransfer(BankTransfer("Bob", "Sally", 100));
transaction(transfer);
```
