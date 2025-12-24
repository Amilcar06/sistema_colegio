package com.unidadeducativa.finanzas.service;

import com.unidadeducativa.finanzas.model.TipoPago;

public interface PaymentGenerationService {
    void generarDeudaMasiva(TipoPago tipoPago);
}
