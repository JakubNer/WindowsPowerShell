Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Choose an item from the provided list of strings and return that string
#
# @param title, title for list chooser
# @param listItems, items to choose from
# 
# @returns null if no choice or choice string
function ShowList {
  ## supportfunction to the Menu function below
  param ($title, [string[]]$listItems)
  
  $coords = ([System.Windows.Forms.Screen]::AllScreens | ? Primary).Bounds.Size

  $width = ($coords.Width / 2)
  $height = ($coords.Height - 200)

  $form = New-Object System.Windows.Forms.Form
  $form.Text = $title
  $form.Size = New-Object System.Drawing.Size($width, $height)
  $form.StartPosition = 'CenterScreen'

  $OKButton = New-Object System.Windows.Forms.Button
  $OKButton.Location = New-Object System.Drawing.Point(75, ($height - 80))
  $OKButton.Size = New-Object System.Drawing.Size(75, 23)
  $OKButton.Text = 'OK'
  $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $form.AcceptButton = $OKButton
  $form.Controls.Add($OKButton)

  $CancelButton = New-Object System.Windows.Forms.Button
  $CancelButton.Location = New-Object System.Drawing.Point(150, ($height - 80))
  $CancelButton.Size = New-Object System.Drawing.Size(75, 23)
  $CancelButton.Text = 'Cancel'
  $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $form.CancelButton = $CancelButton
  $form.Controls.Add($CancelButton)

  $listBox = New-Object System.Windows.Forms.ListBox
  $listBox.Location = New-Object System.Drawing.Point(10, 20)
  $listBox.Size = New-Object System.Drawing.Size(($width - 40), 20)
  $listBox.Height = $height - 100
  foreach ($item in $listItems) {
    [void] $listBox.Items.Add($item)
  }
  $listBox.SelectedIndex = 0

  $form.Controls.Add($listBox)

  $form.Topmost = $true

  if ($listBox.CanFocus) {
    $listBox.Focus()
  } else {
    $listBox.Select()
  }

  $result = $form.ShowDialog()

  if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    return $listBox.SelectedItem;
  }

  return $null
}