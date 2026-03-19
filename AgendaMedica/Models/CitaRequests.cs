using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace AgendaMedica.Models;

public record AgendarCitaRequest
{
    [Required(ErrorMessage = "El ID del médico es obligatorio.")]
    [DefaultValue(1)]
    public int MedicoId { get; init; }

    [Required(ErrorMessage = "El ID del paciente es obligatorio.")]
    [DefaultValue(1)]
    public int PacienteId { get; init; }

    [Required(ErrorMessage = "La fecha es obligatoria.")]
    [DefaultValue(typeof(DateTime), "2026-03-23")]
    public DateTime Fecha { get; init; }

    [Required(ErrorMessage = "La hora de inicio es obligatoria.")]
    [DefaultValue(typeof(TimeSpan), "09:00:00")]
    public TimeSpan HoraInicio { get; init; }

    [Required(ErrorMessage = "El motivo es obligatorio.")]
    [StringLength(500, ErrorMessage = "El motivo no puede exceder 500 caracteres.")]
    [DefaultValue("Consulta general")]
    public string Motivo { get; init; } = null!;
}

public record CancelarCitaRequest
{
    [Required(ErrorMessage = "El motivo de cancelación es obligatorio.")]
    [StringLength(500, ErrorMessage = "El motivo de cancelación no puede exceder 500 caracteres.")]
    [DefaultValue("Paciente solicita reprogramación")]
    public string MotivoCancelacion { get; init; } = null!;
}
