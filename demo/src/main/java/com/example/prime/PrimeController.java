package com.example.prime;

import com.example.prime.service.PrimeNumberService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * REST Controller which serves as an entry-point for requests for prime number information.
 *
 * @author Brendt Lucas
 */
@SpringBootApplication
@RestController
@EnableAutoConfiguration
@RequestMapping("/primes")
@ComponentScan("com.example.prime")
public class PrimeController {

    @Autowired
    private PrimeNumberService primeNumberService;

    /**
     * API Operation that returns a list of prime numbers from 2 to the upperBound (inclusive)
     *
     * @param upperBound The inclusive upper bound to limit the size of the returned primes
     * @return a list of prime numbers from 2 to the upperBound (inclusive)
     */
    @RequestMapping
    List<Integer> primes(@RequestParam(value = "upperBound", defaultValue = "20") int upperBound) {
        return primeNumberService.getPrimes(upperBound);
    }

    /**
     * API Operation that determines if the number (resource) supplied is prime.
     *
     * @param number The number to check if prime
     * @param algorithm The algorithm to use. Defaults to Sieve
     * @return {@code 200} if the number is prime, else {@code 404}
     */
    @RequestMapping(value = "/{number}")
    ResponseEntity prime(@PathVariable int number,
                         @RequestParam(value = "algorithm", required = false, defaultValue = "1") int algorithm) {

        boolean isPrime;
        switch (algorithm) {
            case 2:
                isPrime = primeNumberService.isPrimeFastLoop(number);
                break;
            case 3:
                isPrime = primeNumberService.isPrime(number);
                break;
            default:
                isPrime = primeNumberService.isPrimeSieve(number);
        }

        if (isPrime) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    public static void main(String[] args) {
        SpringApplication.run(PrimeController.class, args);
    }
}
