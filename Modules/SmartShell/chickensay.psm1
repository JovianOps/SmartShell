#
#  Posh-Chickensay
#  PowerShell chickensay — the classic chickensay unix program.
#  Forked from kanej/Posh-Cowsay, reimagined for chicken mode.
#
#  Licensed under the GNU GPL version 3.0
#

#requires -Version 2.0

# Posh-Chickensay Version
$version = "0.3.0"

# Max Width of the Speech Bubble
$bubbleWidth = 40

# The different modes that are supported — swap eyes ($eyes) and tongue ($tongue)
$modes = @{
  "-b" = @("==", " ") # Borg
  "-d" = @("XX", "U") # Dead
  "-g" = @('$$', ' ') # Greedy
  "-p" = @("@@", " ") # Paranoid
  "-s" = @("**", "U") # Stoned
  "-y" = @("..", " ") # Youthful
  "-c" = @("==", "U") # Chicken
}

# Public

<#
.Synopsis
  Prints the given text as if a chicken had said it.
.Description
  Posh-Chickensay generates an ASCII art chicken saying something
  provided by the user. It word-wraps the message at about 40
  columns, and prints the chicken saying the given message on
  standard output.

.Example
  chickensay Bock!

.Example
  "Bock!" | chickensay

.Example
  chickensay -b Resistance is Poultry
#>
function Chickensay() {
  $params

  $messageArgs = @()
  $eyes = "oo"
  $tongue = " "

  foreach($arg in $args) {

    if($arg -eq "-v" -or $arg -eq "-version") {
      Print-Version
      return
    }

    if($modes.keys -contains $arg) {
      $eyes   = $modes[$arg][0]
      $tongue = $modes[$arg][1]
      continue
    }

    $messageArgs += $arg
  }

  $inputList = @($input)
  if ($inputList.Count -eq 0) {
    $params = ,$messageArgs
  } else {
    $params = ,$messageArgs +@($inputList)
  }

  $message = [string[]]$params

  Print-MessageBubble($message)

  Print-Chicken $eyes $tongue
}

# Private

function Print-MessageBubble($message) {
  $lines = Convert-MessageToLines($message)
  $lineWidth = Max-Width($lines)

  Write-MessageBubbleBoundaryLine -lineWidth $lineWidth -boundaryChar '_'

  foreach ($index in 0..($lines.length - 1)) {
    $delimiters = Determine-MessageBubbleDelimiters $index $lines.length
    $paddedLine = ' ' + $lines[$index] + ' '
    Write-MessageBubbleLine -lineWidth $lineWidth -delimiters $delimiters -text $paddedLine
  }

  Write-MessageBubbleBoundaryLine -lineWidth $lineWidth -boundaryChar '-'
}

function Print-Chicken($eyes="oo", $tongue=" ") {
  Write-Output "      \  ^__^"
  Write-Output "       \ ($eyes)\_______"
  Write-Output "         (__)\       )\/"
  Write-Output "         ||  $tongue   |"
  Write-Output "         ||----w |"
  Write-Output "         ||     ||"
}

function Print-Version() {
  Print-MessageBubble("Posh-Chickensay version $version")
  Print-Chicken
}

# Helper Functions

function Convert-MessageToLines($message) {
  $words = Split-Message $message
  $lines = @()
  $line = ""

  foreach($word in $words) {
    if(($line.length + $word.length + 1) -gt $bubbleWidth) {
      if($line -ne "") {
        $lines += ,$line
      }
      $line = $word
    } else {
      if($line -eq "") {
        $line = $word
      } else {
        $line += " " + $word
      }
    }
  }

  $lastLine = $line

  $lines += ,$lastLine
  return ,$lines
}

function Split-Message($message) {
  $wordsSplitOnSpaces = $message.split(" ")

  $words = [string[]]@()

  foreach($longWord in $wordsSplitOnSpaces) {
    $splitWords = Split-Word($longWord)
    foreach($word in $splitWords) {
      if($word -ne "") {
        $words+= ,[string]$word
      }
    }
  }

  return ,[string[]]$words
}

function Split-Word($word) {
  if($word.length -le $bubbleWidth) {
    return ,[string[]]@($word)
  }

  $splits = [string[]]@()

  foreach($i in (0..($word.length / $bubbleWidth))) {
    $startPoint = ($i * $bubbleWidth)
    if(($startPoint + $bubbleWidth) -gt $word.length) {
      $splits += $word.substring($startPoint)
    } else {
      $splits += $word.substring($startPoint, $bubbleWidth)
    }
  }

  return ,[string[]]$splits
}

function Max-Width($lines) {
  $maxLength = 0
  foreach($line in $lines) {
    if($line.length -gt $maxLength) {
      $maxLength = $line.length
    }
  }

  return $maxLength
}

function Write-MessageBubbleBoundaryLine($lineWidth, $boundaryChar) {
  Write-MessageBubbleLine -lineWidth $lineWidth `
                          -delimiters '  ' `
                          -text ("".PadRight($lineWidth + 2, $boundaryChar))
}

function Write-MessageBubbleLine($lineWidth, $delimiters, $text) {
    $line = $delimiters[0] + ($text.padRight($lineWidth + 2, ' ')) + $delimiters[1]
    Write-Output $line.trimEnd()
}

function Determine-MessageBubbleDelimiters($lineNumber, $totalNumberOfLines) {
  # single line
  if($totalNumberOfLines -eq 1) {
    return '<>'
  }

  # first line
  if($lineNumber -eq 0) {
    return '/\'
  }

  # last line
  if($lineNumber -eq ($totalNumberOfLines -1)) {
    return '\\/'
  }

  # middle line
  return '||'
}

# Exports
Export-ModuleMember Chickensay
Export-ModuleMember Split-Word
Export-ModuleMember Split-Message