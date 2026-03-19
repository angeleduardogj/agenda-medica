using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace AgendaMedica.Models;

public record CrearMedicoRequest
{
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(150, ErrorMessage = "El nombre no puede exceder 150 caracteres.")]
    [DefaultValue("Angel Eduardo")]
    public string Nombre { get; init; } = null!;

    [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
    [StringLength(150, ErrorMessage = "El apellido paterno no puede exceder 150 caracteres.")]
    [DefaultValue("Gaxiola")]
    public string ApellidoPaterno { get; init; } = null!;

    [StringLength(150, ErrorMessage = "El apellido materno no puede exceder 150 caracteres.")]
    [DefaultValue("Javier")]
    public string? ApellidoMaterno { get; init; }

    [Required(ErrorMessage = "La especialidad es obligatoria.")]
    [DefaultValue(1)]
    public int EspecialidadId { get; init; }

    [Phone(ErrorMessage = "El formato del teléfono no es válido.")]
    [StringLength(20, ErrorMessage = "El teléfono no puede exceder 20 caracteres.")]
    [DefaultValue("6624707957")]
    public string? Telefono { get; init; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido.")]
    [StringLength(200, ErrorMessage = "El email no puede exceder 200 caracteres.")]
    [DefaultValue("angeleduardogj@gmail.com")]
    public string? Email { get; init; }
}

public record ActualizarMedicoRequest
{
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(150, ErrorMessage = "El nombre no puede exceder 150 caracteres.")]
    [DefaultValue("Angel Eduardo")]
    public string Nombre { get; init; } = null!;

    [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
    [StringLength(150, ErrorMessage = "El apellido paterno no puede exceder 150 caracteres.")]
    [DefaultValue("Gaxiola")]
    public string ApellidoPaterno { get; init; } = null!;

    [StringLength(150, ErrorMessage = "El apellido materno no puede exceder 150 caracteres.")]
    [DefaultValue("Javier")]
    public string? ApellidoMaterno { get; init; }

    [Required(ErrorMessage = "La especialidad es obligatoria.")]
    [DefaultValue(1)]
    public int EspecialidadId { get; init; }

    [Phone(ErrorMessage = "El formato del teléfono no es válido.")]
    [StringLength(20, ErrorMessage = "El teléfono no puede exceder 20 caracteres.")]
    [DefaultValue("6624707957")]
    public string? Telefono { get; init; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido.")]
    [StringLength(200, ErrorMessage = "El email no puede exceder 200 caracteres.")]
    [DefaultValue("angeleduardogj@gmail.com")]
    public string? Email { get; init; }
}

public record CrearHorarioRequest
{
    [Required(ErrorMessage = "El ID del médico es obligatorio.")]
    [DefaultValue(1)]
    public int MedicoId { get; init; }

    [Required(ErrorMessage = "El día de la semana es obligatorio.")]
    [Range(1, 7, ErrorMessage = "El día debe estar entre 1 (Lunes) y 7 (Domingo).")]
    [DefaultValue(1)]
    public int DiaSemana { get; init; }

    [Required(ErrorMessage = "La hora de inicio es obligatoria.")]
    [DefaultValue(typeof(TimeSpan), "08:00:00")]
    public TimeSpan HoraInicio { get; init; }

    [Required(ErrorMessage = "La hora de fin es obligatoria.")]
    [DefaultValue(typeof(TimeSpan), "14:00:00")]
    public TimeSpan HoraFin { get; init; }
}

public record ActualizarHorarioRequest
{
    [Required(ErrorMessage = "El día de la semana es obligatorio.")]
    [Range(1, 7, ErrorMessage = "El día debe estar entre 1 (Lunes) y 7 (Domingo).")]
    [DefaultValue(1)]
    public int DiaSemana { get; init; }

    [Required(ErrorMessage = "La hora de inicio es obligatoria.")]
    [DefaultValue(typeof(TimeSpan), "08:00:00")]
    public TimeSpan HoraInicio { get; init; }

    [Required(ErrorMessage = "La hora de fin es obligatoria.")]
    [DefaultValue(typeof(TimeSpan), "14:00:00")]
    public TimeSpan HoraFin { get; init; }
}
