namespace AgendaMedica.Models;

public class CitaResponse
{
    public int Id { get; set; }
    public int MedicoId { get; set; }
    public int PacienteId { get; set; }
    public DateTime FechaHoraInicio { get; set; }
    public DateTime FechaHoraFin { get; set; }
    public string Motivo { get; set; } = null!;
    public string Estado { get; set; } = null!;
    public string? MotivoCancelacion { get; set; }
    public DateTime? FechaCancelacion { get; set; }
    public DateTime FechaCreacion { get; set; }
    public string? EspecialidadNombre { get; set; }
    public int? DuracionMinutos { get; set; }
    public bool? AlertaCancelaciones { get; set; }
    public int? CancelacionesUltimos30Dias { get; set; }
}

public class CitaConsultaResponse
{
    public int Id { get; set; }
    public int MedicoId { get; set; }
    public string MedicoNombre { get; set; } = null!;
    public int PacienteId { get; set; }
    public string PacienteNombre { get; set; } = null!;
    public DateTime FechaHoraInicio { get; set; }
    public DateTime FechaHoraFin { get; set; }
    public string Motivo { get; set; } = null!;
    public string Estado { get; set; } = null!;
    public string? MotivoCancelacion { get; set; }
    public DateTime? FechaCancelacion { get; set; }
    public DateTime FechaCreacion { get; set; }
    public string EspecialidadNombre { get; set; } = null!;
    public int DuracionMinutos { get; set; }
}

public class HorarioSugeridoResponse
{
    public int MedicoId { get; set; }
    public DateTime FechaHoraInicio { get; set; }
    public DateTime FechaHoraFin { get; set; }
    public string? EspecialidadNombre { get; set; }
    public int DuracionMinutos { get; set; }
    public int DiferenciaMinutosContraSolicitado { get; set; }
}
