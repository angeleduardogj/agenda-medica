using System.ComponentModel.DataAnnotations;

namespace AgendaMedica.Models;

public record CrearPacienteRequest
{
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(150, ErrorMessage = "El nombre no puede exceder 150 caracteres.")]
    public string Nombre { get; init; } = null!;

    [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
    [StringLength(150, ErrorMessage = "El apellido paterno no puede exceder 150 caracteres.")]
    public string ApellidoPaterno { get; init; } = null!;

    [StringLength(150, ErrorMessage = "El apellido materno no puede exceder 150 caracteres.")]
    public string? ApellidoMaterno { get; init; }

    [Required(ErrorMessage = "La fecha de nacimiento es obligatoria.")]
    public DateTime FechaNacimiento { get; init; }

    [Phone(ErrorMessage = "El formato del teléfono no es válido.")]
    [StringLength(20, ErrorMessage = "El teléfono no puede exceder 20 caracteres.")]
    public string? Telefono { get; init; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido.")]
    [StringLength(200, ErrorMessage = "El email no puede exceder 200 caracteres.")]
    public string? Email { get; init; }
}

public record ActualizarPacienteRequest
{
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(150, ErrorMessage = "El nombre no puede exceder 150 caracteres.")]
    public string Nombre { get; init; } = null!;

    [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
    [StringLength(150, ErrorMessage = "El apellido paterno no puede exceder 150 caracteres.")]
    public string ApellidoPaterno { get; init; } = null!;

    [StringLength(150, ErrorMessage = "El apellido materno no puede exceder 150 caracteres.")]
    public string? ApellidoMaterno { get; init; }

    [Required(ErrorMessage = "La fecha de nacimiento es obligatoria.")]
    public DateTime FechaNacimiento { get; init; }

    [Phone(ErrorMessage = "El formato del teléfono no es válido.")]
    [StringLength(20, ErrorMessage = "El teléfono no puede exceder 20 caracteres.")]
    public string? Telefono { get; init; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido.")]
    [StringLength(200, ErrorMessage = "El email no puede exceder 200 caracteres.")]
    public string? Email { get; init; }
}
