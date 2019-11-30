class PromptSegment {
    [String]$PromptText
    [String]$BackgroundColor
    [String]$ForegroundColor
    [String]$Separator
    [String]$SeparatorStyle

    PromptSegment ([String]$PromptText) {
        $this.PromptText = $PromptText
    }
    PromptSegment ([String]$PromptText,[String]$BackgroundColor,[String]$ForegroundColor,[String]$Separator,[String]$SeparatorStyle) {
        $this.PromptText = $PromptText
    }
    PromptSegment ([HashTable]$Hashtable) {
        $Hashtable.keys.foreach{
            $this.$PSItem = $HashTable[$PSItem]
        }
    }
    [String] ToString() {
        return $this.PromptText
    }
}