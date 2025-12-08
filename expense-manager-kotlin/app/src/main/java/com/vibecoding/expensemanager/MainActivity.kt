package com.vibecoding.expensemanager

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.vibecoding.expensemanager.ui.screens.AddExpenseScreen
import com.vibecoding.expensemanager.ui.screens.HomeScreen
import com.vibecoding.expensemanager.ui.screens.SalaryScreen
import com.vibecoding.expensemanager.ui.theme.ExpenseManagerTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            ExpenseManagerTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val navController = rememberNavController()
                    NavHost(navController = navController, startDestination = "home") {
                        composable("home") {
                            HomeScreen(
                                onNavigateToSalary = { navController.navigate("salary") }
                            )
                        }
                        composable("salary") {
                            SalaryScreen(
                                onNavigateBack = { navController.popBackStack() }
                            )
                        }
                        // AddScreen removed from nav since it is now a Dialog in HomeScreen
                        // but keeping the route definition just in case or we can remove logic if we deleted the file?
                        // We will keep the file AddExpenseScreen for reference but it's not used in main flow anymore.
                    }
                }
            }
        }
    }
}
