package com.vibecoding.expensemanager.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import java.text.SimpleDateFormat
import java.util.*

enum class DialogMode {
    INSERT, EDIT, DETAILS, DELETE
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpenseDialog(
    mode: DialogMode,
    expenseToEdit: ExpenseItem? = null,
    onDismiss: () -> Unit,
    onConfirm: (ExpenseItem) -> Unit // Returns the modified/new item
) {
    // State initialization
    var amount by remember { mutableStateOf(expenseToEdit?.amount?.toString() ?: "") }
    var category by remember { mutableStateOf(expenseToEdit?.category ?: "Lazer") }
    // Date is current for Insert, or existing for others. ReadOnly.
    val dateDisplay = remember {
        expenseToEdit?.date ?: SimpleDateFormat("dd/MM/yyyy", Locale.getDefault()).format(Date())
    }

    var expandedCategory by remember { mutableStateOf(false) }
    val categories = listOf("Lazer", "Investimentos", "Estudos", "Responsabilidades", "Alimentação")

    val isReadOnly = mode == DialogMode.DETAILS || mode == DialogMode.DELETE
    val title = when (mode) {
        DialogMode.INSERT -> "Novo Gasto"
        DialogMode.EDIT -> "Editar Gasto"
        DialogMode.DETAILS -> "Detalhes do Gasto"
        DialogMode.DELETE -> "Remover Gasto?"
    }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(title) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                if (mode == DialogMode.DELETE) {
                    Text("Tem certeza que deseja remover este item permanentemente?")
                    Text("Categoria: $category")
                    Text("Valor: R$ $amount")
                } else {
                    // Amount Field
                    OutlinedTextField(
                        value = amount,
                        onValueChange = { if (!isReadOnly) amount = it },
                        label = { Text("Valor (R$)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        readOnly = isReadOnly,
                        enabled = !isReadOnly,
                        modifier = Modifier.fillMaxWidth()
                    )

                    // Category Dropdown
                    Box(modifier = Modifier.fillMaxWidth()) {
                        OutlinedTextField(
                            value = category,
                            onValueChange = {},
                            label = { Text("Categoria") },
                            readOnly = true,
                            enabled = !isReadOnly, // Disable click if read only
                            trailingIcon = { if (!isReadOnly) Icon(Icons.Default.ArrowDropDown, null) },
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable(enabled = !isReadOnly) { expandedCategory = true }
                        )
                        DropdownMenu(
                            expanded = expandedCategory,
                            onDismissRequest = { expandedCategory = false }
                        ) {
                            categories.forEach { cat ->
                                DropdownMenuItem(
                                    text = { Text(cat) },
                                    onClick = {
                                        category = cat
                                        expandedCategory = false
                                    }
                                )
                            }
                        }
                    }

                    // Date Field (Always ReadOnly as per requirement)
                    OutlinedTextField(
                        value = dateDisplay,
                        onValueChange = {},
                        label = { Text("Data de Inserção") },
                        readOnly = true, // User requested readonly
                        enabled = false, // Visual cue
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    val finalAmount = amount.toDoubleOrNull() ?: 0.0
                    onConfirm(ExpenseItem(
                        id = expenseToEdit?.id ?: UUID.randomUUID().toString(),
                        amount = finalAmount,
                        category = category,
                        date = dateDisplay
                    ))
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = if (mode == DialogMode.DELETE) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.primary
                )
            ) {
                Text(if (mode == DialogMode.DELETE) "Remover" else "Salvar")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancelar")
            }
        }
    )
}

// Simple Data Class for Mocking
data class ExpenseItem(
    val id: String,
    val amount: Double,
    val category: String,
    val date: String
)
