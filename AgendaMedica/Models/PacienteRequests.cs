using System.ComponentModel.DataAnnotations;
using System.ComponentModel;

namespace AgendaMedica.Models;

public record CrearPacienteRequest
{
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(150, ErrorMessage = "El nombre no puede exceder 150 caracteres.")]
    [DefaultValue("Juan")]
    public string Nombre { get; init; } = null!;

    [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
    [StringLength(150, ErrorMessage = "El apellido paterno no puede exceder 150 caracteres.")]
    [DefaultValue("Perez")]
    public string ApellidoPaterno { get; init; } = null!;

    [StringLength(150, ErrorMessage = "El apellido materno no puede exceder 150 caracteres.")]
    [DefaultValue("Gomez")]
    public string? ApellidoMaterno { get; init; }

    [Required(ErrorMessage = "La fecha de nacimiento es obligatoria.")]
    [DefaultValue(typeof(DateTime), "1990-01-15")]
    public DateTime FechaNacimiento { get; init; }

    [Phone(ErrorMessage = "El formato del teléfono no es válido.")]
    [StringLength(20, ErrorMessage = "El teléfono no puede exceder 20 caracteres.")]
    [DefaultValue("5551234567")]
    public string? Telefono { get; init; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido.")]
    [StringLength(200, ErrorMessage = "El email no puede exceder 200 caracteres.")]
    [DefaultValue("juan.perez@email.com")]
    public string? Email { get; init; }
}

public record ActualizarPacienteRequest
{
    [Required(ErrorMessage = "El nombre es obligatorio.")]
    [StringLength(150, ErrorMessage = "El nombre no puede exceder 150 caracteres.")]
    [DefaultValue("Juan")]
    public string Nombre { get; init; } = null!;

    [Required(ErrorMessage = "El apellido paterno es obligatorio.")]
    [StringLength(150, ErrorMessage = "El apellido paterno no puede exceder 150 caracteres.")]
    [DefaultValue("Perez")]
    public string ApellidoPaterno { get; init; } = null!;

    [StringLength(150, ErrorMessage = "El apellido materno no puede exceder 150 caracteres.")]
    [DefaultValue("Gomez")]
    public string? ApellidoMaterno { get; init; }

    [Required(ErrorMessage = "La fecha de nacimiento es obligatoria.")]
    [DefaultValue(typeof(DateTime), "1990-01-15")]
    public DateTime FechaNacimiento { get; init; }

    [Phone(ErrorMessage = "El formato del teléfono no es válido.")]
    [StringLength(20, ErrorMessage = "El teléfono no puede exceder 20 caracteres.")]
    [DefaultValue("5551234567")]
    public string? Telefono { get; init; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido.")]
    [StringLength(200, ErrorMessage = "El email no puede exceder 200 caracteres.")]
    [DefaultValue("juan.perez@email.com")]
    public string? Email { get; init; }
}
