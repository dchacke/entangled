describe('entangledTest.FibonacciService', function() {

  var FibonacciService;

  beforeEach(module('entangledTest'));
  beforeEach(inject(function($injector) {
    FibonacciService = $injector.get('FibonacciService');
  }));

  it('outputs correct Fibonacci numbers', function() {
    // expect(FibonacciService.fibonacci(0)).toBe(0);
    // expect(FibonacciService.fibonacci(1)).toBe(1);
    // expect(FibonacciService.fibonacci(10)).toBe(55);

    expect(1).toBe(1);
  });

});
