@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @(
        # CLI-скрипты намеренно пишут статус в хост, а не только в конвейер
        'PSAvoidUsingWriteHost'
    )
}
