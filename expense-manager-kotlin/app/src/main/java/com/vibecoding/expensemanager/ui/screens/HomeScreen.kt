package com.vibecoding.expensemanager.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AttachMoney
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToSalary: () -> Unit
) {
    // Mock Data
    val initialList = listOf(
        ExpenseItem("1", 50.0, "Lazer", "08/12/2025"),
        ExpenseItem("2", 120.0, "Alimentação", "07/12/2025"),
        ExpenseItem("3", 2000.0, "Responsabilidades", "01/12/2025")
    )
    
    // State for List
    var expenseList by remember { mutableStateOf(initialList) }

    // State for Dialog
    var showDialog by remember { mutableStateOf(false) }
    var currentMode by remember { mutableStateOf(DialogMode.INSERT) }
    var selectedItem by remember { mutableStateOf<ExpenseItem?>(null) }

    // Helper to open dialog
    fun openDialog(mode: DialogMode, item: ExpenseItem? = null) {
        currentMode = mode
        selectedItem = item
        showDialog = true
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Meus Gastos") },
                actions = {
                    TextButton(onClick = onNavigateToSalary) {
                        Text("Salário", color = MaterialTheme.colorScheme.onSurface)
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { openDialog(DialogMode.INSERT) }) {
                Icon(Icons.Default.Add, contentDescription = "Novo Gasto")
            }
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .padding(innerPadding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(expenseList) { item ->
                ExpenseCard(
                    item = item,
                    onDetails = { openDialog(DialogMode.DETAILS, item) },
                    onEdit = { openDialog(DialogMode.EDIT, item) },
                    onDelete = { openDialog(DialogMode.DELETE, item) }
                )
            }
        }

        if (showDialog) {
            ExpenseDialog(
                mode = currentMode,
                expenseToEdit = selectedItem,
                onDismiss = { showDialog = false },
                onConfirm = { resultItem ->
                    when (currentMode) {
                        DialogMode.INSERT -> {
                            expenseList = expenseList + resultItem
                        }
                        DialogMode.EDIT -> {
                            expenseList = expenseList.map { if (it.id == resultItem.id) resultItem else it }
                        }
                        DialogMode.DELETE -> {
                            expenseList = expenseList.filter { it.id != selectedItem?.id }
                        }
                        DialogMode.DETAILS -> { /* Do nothing */ }
                    }
                    showDialog = false
                }
            )
        }
    }
}

@Composable
fun ExpenseCard(
    item: ExpenseItem,
    onDetails: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(
            modifier = Modifier
                .padding(12.dp)
                .fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(text = item.category, style = MaterialTheme.typography.titleMedium)
                Text(text = item.date, style = MaterialTheme.typography.bodySmall)
            }
            
            Text(
                text = "R$ ${item.amount}", 
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(end = 8.dp)
            )

            // Action Icons
            Row {
                IconButton(onClick = onDetails) { Icon(Icons.Default.Info, "Detalhes", tint = MaterialTheme.colorScheme.secondary) }
                IconButton(onClick = onEdit) { Icon(Icons.Default.Edit, "Editar", tint = MaterialTheme.colorScheme.tertiary) }
                IconButton(onClick = onDelete) { Icon(Icons.Default.Delete, "Remover", tint = MaterialTheme.colorScheme.error) }
            }
        }
    }
}
