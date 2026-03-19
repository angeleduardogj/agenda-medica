using System.ComponentModel.DataAnnotations;

namespace AgendaMedica.Models;

public record AgendarCitaRequest
{
    [Required(ErrorMessage = "El ID del médico es obligatorio.")]
    public int MedicoId { get; init; }

    [Required(ErrorMessage = "El ID del paciente es obligatorio.")]
    public int PacienteId { get; init; }

    [Required(ErrorMessage = "La fecha es obligatoria.")]
    public DateTime Fecha { get; init; }

    [Required(ErrorMessage = "La hora de inicio es obligatoria.")]
    public TimeSpan HoraInicio { get; init; }

    [Required(ErrorMessage = "El motivo es obligatorio.")]
    [StringLength(500, ErrorMessage = "El motivo no puede exceder 500 caracteres.")]
    public string Motivo { get; init; } = null!;
}

public record CancelarCitaRequest
{
    [Required(ErrorMessage = "El motivo de cancelación es obligatorio.")]
    [StringLength(500, ErrorMessage = "El motivo de cancelación no puede exceder 500 caracteres.")]
    public string MotivoCancelacion { get; init; } = null!;
}
