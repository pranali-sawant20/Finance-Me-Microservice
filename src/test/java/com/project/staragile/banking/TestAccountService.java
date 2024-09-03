package com.project.staragile.banking;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class TestAccountService {

    @Autowired
    AccountService accountService;

    @Test
    public void testAccountRegistration() {
        Account account = new Account(3030303030L, "Alice", "Saving Account", 30000.0);
        Account registeredAccount = accountService.registerAccount(account);
        assertNotNull(registeredAccount);
        assertEquals(account.getAccountNumber(), registeredAccount.getAccountNumber());
        assertEquals(account.getAccountName(), registeredAccount.getAccountName());
        assertEquals(account.getAccountType(), registeredAccount.getAccountType());
        assertEquals(account.getAccountBalance(), registeredAccount.getAccountBalance());
    }

    @Test
    public void testGetAccountDetails() {
        Account account = new Account(4040404040L, "Bob", "Current Account", 40000.0);
        accountService.registerAccount(account);
        Account fetchedAccount = accountService.getAccountDetails(4040404040L);
        assertNotNull(fetchedAccount);
        assertEquals("Bob", fetchedAccount.getAccountName());
    }

    @Test
    public void testUpdateAccount() {
        Account account = new Account(5050505050L, "Charlie", "Saving Account", 50000.0);
        accountService.registerAccount(account);

        Account updatedAccount = new Account();
        updatedAccount.setAccountName("Charlie Updated");
        updatedAccount.setAccountType("Current Account");
        updatedAccount.setAccountBalance(60000.0);

        Account result = accountService.updateAccount(5050505050L, updatedAccount);
        assertNotNull(result);
        assertEquals("Charlie Updated", result.getAccountName());
        assertEquals("Current Account", result.getAccountType());
        assertEquals(60000.0, result.getAccountBalance());
    }

    @Test
    public void testDeleteAccount() {
        Account account = new Account(6060606060L, "David", "Saving Account", 60000.0);
        accountService.registerAccount(account);
        boolean isDeleted = accountService.deleteAccount(6060606060L);
        assertEquals(true, isDeleted);
        Account deletedAccount = accountService.getAccountDetails(6060606060L);
        assertNull(deletedAccount);
    }
}