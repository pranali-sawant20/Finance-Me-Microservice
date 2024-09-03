package com.project.staragile.banking;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AccountService {

    @Autowired
    AccountRepository accountRepository;

    public Account createAccount() {
        Account account = new Account(1010101010, "Shubham", "Saving Account", 20000.0);
        return accountRepository.save(account);
    }

    public Account registerAccount(Account account) {
        return accountRepository.save(account);
    }

    public Account getAccountDetails(int accountNumber) {
        return accountRepository.findById(accountNumber).orElse(null);
    }

    public Account updateAccount(int accountNumber, Account updatedAccount) {
        Optional<Account> optionalAccount = accountRepository.findById(accountNumber);
        if (optionalAccount.isPresent()) {
            Account existingAccount = optionalAccount.get();
            existingAccount.setAccountName(updatedAccount.getAccountName());
            existingAccount.setAccountType(updatedAccount.getAccountType());
            existingAccount.setAccountBalance(updatedAccount.getAccountBalance());
            return accountRepository.save(existingAccount);
        } else {
            return null;
        }
    }

    public boolean deleteAccount(int accountNumber) {
        Optional<Account> optionalAccount = accountRepository.findById(accountNumber);
        if (optionalAccount.isPresent()) {
            accountRepository.deleteById(accountNumber);  // Use deleteById if available
            return true;
        } else {
            return false;
        }
    }

    // Adding the registerDummyAccount() method
    public Account registerDummyAccount() {
        Account account = new Account(1010101010, "Shubham", "Saving Account", 20000.0);
        return accountRepository.save(account);
    }
}
