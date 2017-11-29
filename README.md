# Cancelling operations blocks in an OperationQueue

## Main
```
let fakeObject = FakeClass()
fakeObject.start()
fakeObject.exitAndCancelOperations()
```

## fakeObject.start()
### 1. Creates 3 operation blocks
#### Operation 1 calls `checkFacebook()`
```
let operationBlock1 = BlockOperation()
operationBlock1.addExecutionBlock { [unowned operationBlock1] in
  guard !operationBlock1.isCancelled else {
    print("Operation 1: Cancelled")
    return
  }
  
  self.checkFacebook()
}
```
#### Operation 2 calls `startExecise()` and `endExecise()`
```
let operationBlock2 = BlockOperation()
operationBlock2.addExecutionBlock { [unowned operationBlock2] in
  guard !operationBlock2.isCancelled else {
    print("Operation 2 (exercise): Cancelled before startExecise even starts")
    return
  }
	
  self.startExecise()
	
  guard !operationBlock2.isCancelled else {
    print("Operation 2 (exercise): Cancelled before it finishes")
    return
	}
  
  self.endExecise() //Will not reach this point because it has already been cancelled
}
```
#### Operation 3 calls `getCoffee()` and `drinkCoffee()`
```
let operationBlock3 = BlockOperation()
operationBlock3.addExecutionBlock { [unowned operationBlock3] in
	
  self.getCoffee() //Will not reach this point because it has already been cancelled
  
  guard !operationBlock3.isCancelled else {
	  print("Operation 3: Cancelled")
    return
  }

  self.drinkCoffee()
}
```
### 2. Adds the 3 operation blocks to the operationQueue (underlying queue is a background serial queue)
```
operationQueue.addOperation(operationBlock1) //checkFacebook
operationQueue.addOperation(operationBlock2) //exercise
operationQueue.addOperation(operationBlock3) //coffee
```

## fakeObject.exitAndCancelOperations()
#### Calls `operationQueue.cancelAllOperations()`
```
func exitAndCancelOperations(in operationQueue: OperationQueue) {
  print("Cancelling all operations.")
  operationQueue.cancelAllOperations()
}
```

## Output in console log 
### `operationQueue.cancelAllOperations()` is called
```
Operation 1 (checkFacebook): Started
Operation 1 (checkFacebook): Completed.
Operation 2 (exercise): Started
Cancelling all operations.
Operation 2 (exercise): Cancelled before it finishes
Done!
```

### For comparison, this is the output if `operationQueue.cancelAllOperations()` is not called/commented out
```
Operation 1 (checkFacebook): Started
Operation 1 (checkFacebook): Completed.
Operation 2 (exercise): Started
Operation 2 (exercise): Completed
Operation 3 (coffee): Started
Operation 3 (coffee): Completed.
Done!
```

## [Apple Documentation](https://developer.apple.com/documentation/foundation/operationqueue/1417849-cancelalloperations)
### `cancelAllOperations()` - Canceling the operations does not automatically remove them from the queue or stop those that are currently executing. For operations that are queued and waiting execution, the queue must still attempt to execute the operation before recognizing that it is canceled and moving it to the finished state.

Notes: `operationBlock3` didn't even execute because cancelAllOperations() was called before it even started

### For operations that are already executing, the operation object itself must check for cancellation and stop what it is doing so that it can move to the finished state. In both cases, a finished (or canceled) operation is still given a chance to execute its completion block before it is removed from the queue.
Notes: Since `operationBlock2` already started executing, adding `guard !operationBlock.isCancelled else { return }` give you the ability to cancel it
