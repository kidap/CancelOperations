//: Playground - noun: a place where people can play
import Foundation

//How to cancel operations when using OperationQueue

// cancelAllOperations() - Canceling the operations does not automatically remove them from the queue or stop those that are currently executing.

//For operations that are queued and waiting execution, the queue must still attempt to execute the operation before recognizing that it is canceled and moving it to the finished state.
// `operationBlock3` didn't even execute because cancelAllOperations() was called before it even started

// For operations that are already executing, the operation object itself must check for cancellation and stop what it is doing so that it can move to the finished state. In both cases, a finished (or canceled) operation is still given a chance to execute its completion block before it is removed from the queue.
// Since `operationBlock2` already started executing, adding `guard !operationBlock.isCancelled else { return }` give you the ability to cancel it


class FakeClass {
	let operationQueue: OperationQueue = {
		let operationQueue = OperationQueue()
		operationQueue.qualityOfService = .background
		operationQueue.underlyingQueue = DispatchQueue(label: "com.test.concurrency")
		return operationQueue
	}()

	func start() {
		let operationBlock1 = BlockOperation()
		operationBlock1.addExecutionBlock { [unowned operationBlock1] in
			guard !operationBlock1.isCancelled else {
				print("Operation 1: Cancelled")
				return
			}
			self.checkFacebook()
		}
		
		let operationBlock2 = BlockOperation()
		operationBlock2.addExecutionBlock {[unowned operationBlock2] in
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
		
		let operationBlock3 = BlockOperation()
		operationBlock3.addExecutionBlock { [unowned operationBlock3] in
			self.getCoffee() //Will not reach this point because it has already been cancelled
			guard !operationBlock3.isCancelled else {
				print("Operation 3: Cancelled")
				return
			}
			self.drinkCoffee()
		}
		
		operationQueue.addOperation(operationBlock1)
		operationQueue.addOperation(operationBlock2)
		operationQueue.addOperation(operationBlock3)
		
		refreshViewOrSomething()
		
	}
	
	func exitAndCancelOperations() {
		exitAndCancelOperations(in: operationQueue)
		
		sleep(5) //To allow operation blocks to try to complete
		print("Done!")
	}
}

private extension FakeClass {
	func checkFacebook() {
		print("Operation 1 (checkFacebook): Started")
		sleep(1)
		print("Operation 1 (checkFacebook): Completed.")
	}
	
	func startExecise() {
		print("Operation 2 (exercise): Started")
		sleep(3)
	}
	
	func endExecise() {
		print("Operation 2 (exercise): Completed")
	}
	
	func getCoffee() {
		print("Operation 3 (coffee): Started")
	}
	
	func drinkCoffee() {
		print("Operation 3 (coffee): Completed.")
	}
	
	func refreshViewOrSomething(){
		sleep(2)
	}
	
	func exitAndCancelOperations(in operationQueue: OperationQueue) {
		print("Cancelling all operations.")
		operationQueue.cancelAllOperations()
	}
}
//------------------------------------------------------------------------
// Main
//------------------------------------------------------------------------
let fakeObject = FakeClass()
fakeObject.start()
fakeObject.exitAndCancelOperations()
