trigger ProductDuplicateCheck on Product2 (before insert) {
    // Mapeia os EAN13 dos produtos sendo inseridos
    Set<String> ean13Set = new Set<String>();
    
    for (Product2 p : Trigger.new) {
        if (String.isNotBlank(p.EAN13__c)) {
            ean13Set.add(p.EAN13__c);
        }
    }
    
    if (!ean13Set.isEmpty()) {
        // Busca no banco de dados produtos ativos com o mesmo EAN13
        Map<String, Product2> produtosAtivos = new Map<String, Product2>();
        
        for (Product2 p : [SELECT Id, EAN13__c FROM Product2 WHERE EAN13__c IN :ean13Set AND IsActive = true]) {
            produtosAtivos.put(p.EAN13__c, p);
        }
        
        // Valida se algum dos produtos a serem inseridos já existe como ativo
        for (Product2 p : Trigger.new) {
            if (produtosAtivos.containsKey(p.EAN13__c)) {
                p.addError('Já existe um produto ativo com o EAN13 ' + p.EAN13__c + ' no sistema.');
            }
        }
    }
}