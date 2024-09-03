package com.project.staragile.banking;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
public class AccountController {

    @Autowired
    AccountService accountService;

    @GetMapping("/sayHello")
    public String sayHello() {
        return "Hello from CBS Bank";
    }

    @GetMapping("/createAccount")
    public Account createAccount() {
        return accountService.createAccount();
    }

    @PostMapping("/registerAccount")
    public ResponseEntity<Account> registerAccount(@RequestBody Account account) {
        if (account != null) {
            Account createdAccount = accountService.registerAccount(account);
            return new ResponseEntity<>(createdAccount, HttpStatus.CREATED);
        }
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    @GetMapping("/getAccount/{accountNumber}")
    public ResponseEntity<Account> getAccountDetails(@PathVariable(value = "accountNumber") int accountNumber) {
        Account account = accountService.getAccountDetails(accountNumber);
        if (account != null) {
            return new ResponseEntity<>(account, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @PutMapping("/updateAccount/{accountNumber}")
    public ResponseEntity<Account> updateAccount(@PathVariable int accountNumber, @RequestBody Account updatedAccount) {
        Account account = accountService.updateAccount(accountNumber, updatedAccount);
        if (account != null) {
            return new ResponseEntity<>(account, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/viewPolicy/{accountNumber}")
    public ResponseEntity<?> viewPolicy(@PathVariable int accountNumber) {
        Account account = accountService.getAccountDetails(accountNumber);
        if (account != null) {
            return new ResponseEntity<>(account, HttpStatus.OK);
        } else {
            Map<String, String> response = new HashMap<>();
            response.put("message", "Account not found.");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
    }

    @DeleteMapping("/deletePolicy/{accountNumber}")
    public ResponseEntity<Map<String, String>> deletePolicy(@PathVariable int accountNumber) {
        boolean isDeleted = accountService.deleteAccount(accountNumber);
        Map<String, String> response = new HashMap<>();
        if (isDeleted) {
            response.put("message", "Account deleted successfully.");
            return new ResponseEntity<>(response, HttpStatus.OK);
        } else {
            response.put("message", "Account not found.");
            return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
        }
    }
}
