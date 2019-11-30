using namespace System.Collections.Generic
#NOTE: I tried inheriting List[String] but iCollections do weird stuff in powershell with adding and subtracting, auto
#converting into Object arrays rather than the requested Op_Addition behavior
class PromptBuilder {
    #The prompt segments included
    [List[PromptSegment]]$Prompt = [List[PromptSegment]]::new()

    #The seed for the random colors selected when the prompt is built, if you don't specify one.
    [int]$PromptColorSeed = 0

    PromptBuilder () {
        $this
    }
    PromptBuilder ([String[]]$String) {
        $String.Foreach{
            $this.Add([String]$PSItem)
        }
    }
    PromptBuilder ([String]$String) {
        $this.add($String)
    }
    PromptBuilder ([PromptSegment]$PromptSegment) {
        $this.add($PromptSegment)
    }

    #Pass through these methods to the List object
    [void] Add([PromptSegment]$String) {
        $this.Prompt.Add($String)
    }
    [void] Remove([PromptSegment]$String) {
        $this.Prompt.Remove($String)
    }

    #Enable use of the powershell + and += operators
    static [PromptBuilder] Op_Addition(
        [PromptBuilder]$Left,
        [PromptSegment]$Right
    ) {
        $Left.Add($Right)
        return $Left
    }

    #Enable use of the powershell - and -= operators
    static [PromptBuilder] Op_Subtraction(
        [PromptBuilder]$Left,
        [PromptSegment]$Right
    ) {
        $Left.Remove($Right)
        return $Left
    }

    # Output the resulting prompt
    [String] ToString() {
        #Set a seed for the prompt segments to keep the order consistent
        Get-Random -SetSeed $this.PromptColorSeed > $null

        [String]$promptOutput = $null
        foreach ($PromptItem in $this.prompt) {
            $AddPowerPromptParams = @{InputObject = $PromptItem.PromptText}
            ('BackgroundColor','ForegroundColor','Separator').foreach{
                if ($PromptItem.$PSItem) {
                    $AddPowerPromptParams.$PSItem = $PromptItem.$PSItem
                }
            }
            $promptOutput = $promptOutput | Add-PowerPrompt @AddPowerPromptParams
        }

        #Re-randomize so we don't affect other applications potentially
        Get-Random -SetSeed ([datetime]::now.millisecond) > $null
        return $promptOutput
    }
}